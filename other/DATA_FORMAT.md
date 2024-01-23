## Data format

Each dataset, ie a single continuous recording of sensor data, is made out of a single folder with the following contents:

* `data.jsonl` in the format described [below](#jsonl-format).
* `data.mkv` (or other video file extension) for monocular camera.
* (optional) `data2.mkv` second camera for stereo/depth recordings.
* `calibration.json` see [Calibration format](#calibration-format) below.
* (optional) `vio_config.yaml` Algorithm parameters for Spectacular AI SDK

## JSONL format

This section defines the [JSON Lines](https://jsonlines.org/) -based data format. The format can include sensor data used as input and pose estimates produced by different VIO methods.

### Timestamps

Each JSONL line that describes temporal data should have a `time` field at the root using seconds as units. The whole JSONL file is preferably sorted by these timestamps in ascending order. The timestamps may begin from any value, including negative ones. Starting from close to zero may avoid possible issues with floating point accuracy.

### Inertial sensors (IMU)

IMU and other "N-axis" sensors define a `sensor` field with sub-fields `type` and `values`. The units for `values` are m/s^2 for `accelerometer`, rad/s for `gyroscope`, μT for `magnetometer`, and K for `imuTemperature`.

### Camera frames

For each frame in `data.mp4`, and a perfectly synchronized `data2.mp4` in case of stereo/depth, there is a single line with `frames` in the root whose array value lists outputs for each camera. The `number` field starts from 0 and increments by one per frame. `cameraInd` 0 refers to `data.mp4` and 1 to `data2.mp4`. `cameraParameters` can be used to set per-frame parameters, otherwise constant values from `calibration.json` are used. So a minimal (monocular) line looks like this:

```
{ "frames": [{ "cameraInd": 0 }], "number": 0, "time": 0.0 }
```

### GNSS

Defines `gps` in the root with the fields `longitude`, `latitude`, and `altitude` (meters) in the [Geographic coordinate system](https://en.wikipedia.org/wiki/Geographic_coordinate_system). The field `accuracy` has no precise definition, but in most cases is a distance (meters) corresponding to a given confidence level. An optional `verticalAccuracy` for accuracy of `altitude` can also be included.

### Ground truth and VIO output

Defines `groundTruth` or name of a VIO method in the root, with subfields `position` (`t`) and optionally `orientation` (`q`). Position is given in meters, with negative z-axis pointing along gravity. Orientation is given as a unit quaternion. Together these define a 4x4 matrix `T = [R(q), t; 0, 1]` that transforms homogeneous device coordinates `p_d` to world coordinates `p_w` by left-multiplication `p_w = T * p_d`.

### LIDAR

Lidar data has `lidar` field that contains an object with `model` field defining the data type and `dataFile` relative file location to the binary data that contains the lidar measurements.

#### Model: "RoboSense M1 XYZIRT"

Below is C++ header defining binary format for `RoboSense M1 XYZIRT` lidar model. The binary file is simply an array of these values. The data is otherwise raw from the LIDAR sensor except time, which has been synchronized with other data sources:
```
#pragma pack(push)
#pragma pack(1)
struct LidarRoboSenseXYZIRT {
  float x;
  float y;
  float z;
  uint8_t intensity;
  uint16_t ring;
  double timestamp;
};
#pragma pack(pop)
```

You can read the binary file in C++ like so, assuming `jsonlLine` is the JSONL line:
```
std::ifstream lidarFile(jsonlLine["lidar"]["dataFile"].c_str(), std::ios::binary);
LidarRoboSenseXYZIRT d;
while (lidarFile.read(reinterpret_cast<char*>(&d), sizeof(LidarRoboSenseXYZIRT))) {
    // Do something with single lidar point
}
```

### Example data.jsonl

```
{"groundTruth":{"position":{"x":-0.007567568216472864,"y":0.022782884538173676,"z":0.00817866250872612},"orientation":{"w":0.53464,"x":-0.15299,"y":-0.826976,"z":-0.082863}},"time":1.444770263671875}
{"sensor":{"type":"accelerometer","values":[-0.03824593499302864,9.121655464172363,-2.983182907104492]},"time":1.43846240234375}
{"sensor":{"type":"gyroscope","values":[0.003195890923961997,-0.17364339530467987,0.015979453921318054]},"time":1.44976953125}
{"sensor":{"type":"imuTemperature","values":[292.8961]},"time":1.44976953125}
{"groundTruth":{"position":{"x":-0.007713410072028637,"y":0.022989293560385704,"z":0.008272084407508373},"orientation":{"w":0.53464,"x":-0.15299,"y":-0.826976,"z":-0.082863}},"time":1.449769287109375}
{"frames":[{"cameraInd":0,"cameraParameters":{"focalLengthX":284.929992675781,"focalLengthY":285.165496826172,"principalPointX":416.4547119140625,"principalPointY":395.77349853515625,"distortionModel":"KANNALA_BRANDT4","distortionCoefficients":[-0.004973,0.03975,-0.0374,0.006239]},"imuToCamera":[[0.01486,0.9995,-0.02577,0.06522],[-0.9998,0.01496,0.003756,-0.0207],[0.00414,0.02571,0.9996,-0.008054],[0,0,0,1]],"time":1.436207275390625},{"cameraInd":1,"cameraParameters":{"focalLengthX":284.559509277344,"focalLengthY":284.4418029785162,"principalPointX":410.81329345703125,"principalPointY":394.1506042480469,"distortionModel":"KANNALA_BRANDT4","distortionCoefficients":[-0.006496,0.04365,-0.04025,0.006813]},"imuToCamera":[[0.01255,0.9995,-0.02538,-0.0449],[-0.9997,0.01301,0.0179,-0.02056],[0.01822,0.02515,0.9995,-0.008638],[0,0,0,1]],"time":1.436207275390625}],"number":28,"time":1.436207275390625}
{"sensor":{"type":"gyroscope","values":[-0.025567127391695976,-0.16512103378772736,0.034089501947164536]},"time":1.4547685546875}
{"sensor":{"type":"imuTemperature","values":[292.8961]},"time":1.4547685546875}
{"groundTruth":{"position":{"x":-0.00783445406705141,"y":0.02315470017492771,"z":0.008362464606761932},"orientation":{"w":0.53464,"x":-0.15299,"y":-0.826976,"z":-0.082863}},"time":1.45476806640625}
{"sensor":{"type":"gyroscope","values":[-0.07137490063905716,-0.1523374617099762,0.04793836548924446]},"time":1.45976806640625}
{"sensor":{"type":"imuTemperature","values":[292.8961]},"time":1.45976806640625}
{"groundTruth":{"position":{"x":-0.007959198206663132,"y":0.023323576897382736,"z":0.008457313291728497},"orientation":{"w":0.53464,"x":-0.15299,"y":-0.826976,"z":-0.082863}},"time":1.459767333984375}
{"sensor":{"type":"accelerometer","values":[0.4015823304653168,9.446745872497559,-2.8301992416381836]},"time":1.4539404296875}
{"sensor":{"type":"gyroscope","values":[-0.12037855386734009,-0.12037855386734009,0.07457078248262405]},"time":1.46476708984375}
{"sensor":{"type":"imuTemperature","values":[292.8961]},"time":1.46476708984375}
{"groundTruth":{"position":{"x":-0.008127331733703613,"y":0.023527292534708977,"z":0.008570007979869843},"orientation":{"w":0.53464,"x":-0.15299,"y":-0.826976,"z":-0.082863}},"time":1.464766357421875}
{"frames":[{"cameraInd":0,"cameraParameters":{"focalLengthX":284.929992675781,"focalLengthY":285.165496826172,"principalPointX":416.4547119140625,"principalPointY":395.77349853515625,"distortionModel":"KANNALA_BRANDT4","distortionCoefficients":[-0.004973,0.03975,-0.0374,0.006239]},"imuToCamera":[[0.01486,0.9995,-0.02577,0.06522],[-0.9998,0.01496,0.003756,-0.0207],[0.00414,0.02571,0.9996,-0.008054],[0,0,0,1]],"time":1.46955859375},{"cameraInd":1,"cameraParameters":{"focalLengthX":284.559509277344,"focalLengthY":284.4418029785162,"principalPointX":410.81329345703125,"principalPointY":394.1506042480469,"distortionModel":"KANNALA_BRANDT4","distortionCoefficients":[-0.006496,0.04365,-0.04025,0.006813]},"imuToCamera":[[0.01255,0.9995,-0.02538,-0.0449],[-0.9997,0.01301,0.0179,-0.02056],[0.01822,0.02515,0.9995,-0.008638],[0,0,0,1]],"time":1.46955859375}],"number":29,"time":1.46955859375}
{"sensor":{"type":"gyroscope","values":[-0.15979453921318054,-0.08735434710979462,0.08841964602470398]},"time":1.4697841796875}
{"sensor":{"type":"imuTemperature","values":[292.8961]},"time":1.4697841796875}
{"groundTruth":{"position":{"x":-0.007131610997021198,"y":0.022098174318671227,"z":0.008283869363367558},"orientation":{"w":0.53464,"x":-0.15299,"y":-0.826976,"z":-0.082863}},"time":1.469782958984375}
{"sensor":{"type":"gyroscope","values":[-0.18323107063770294,-0.06178722158074379,0.09481143206357956]},"time":1.474782958984375}
{"gps": {"accuracy": 4.0, "altitude": 14.18831106834269, "latitude": 60.173783793064594, "longitude": 24.906486344581662}, "time":1.474782958984375}
```

## Calibration format

Camera intrinsic and extrinsic parameters must be defined using a `calibration.json` file with the following fields:

* `cameras`: An array of objects with the following fields, one element for monocular and two for stereo.
* `focalLengthX`: Horizontal focal length.
* `focalLengthY`: Vertical focal length.
* `principalPointX` (pixels): Horizontal principal point.
* `principalPointY` (pixels): Vertical principal point.
* `model`: For example `pinhole`, `kannala-brandt4`, `brown-conrady` etc.
* `distortionCoefficients`: Array of values depending on `model`. For example `kannala-brandt4` requires 4 numbers, and `pinhole` 0 or 3 (no distortion and OpenCV radtan distortion model with only some radial components).
* `imuToCameraMatrix`: A 4x4 matrix that transforms homogeneous coordinates as: `p_camera = T * p_imu`.
* `imageWidth` and `imageHeight` (pixels): Image size that the focal lenghts and principal point are given with reference to.

### Example calibration.json

```
{
    "cameras": [
        {
            "distortionCoefficients": [
                -0.02772200817284449,
                0.0020816404470823564,
                -0.005219319585905603,
                0.00044346633058214575
            ],
            "focalLengthX": 547.5542611995533,
            "focalLengthY": 547.4728273665322,
            "imuToCamera": [
                [
                    -0.004028958399374893,
                    -0.9999835791608805,
                    0.0040754021655989925,
                    0.00026667580381220524
                ],
                [
                    -0.9999788711605716,
                    0.004049663285094152,
                    0.0050850230782564345,
                    0.03338442163595494
                ],
                [
                    -0.005101443584432566,
                    -0.004054828710638873,
                    -0.9999787665933124,
                    0.0011383544698017876
                ],
                [
                    0.0,
                    0.0,
                    0.0,
                    1.0
                ]
            ],
            "model": "kannala-brandt4",
            "principalPointX": 672.6648243249832,
            "principalPointY": 490.44200513757215,
            "imageWidth": 1344,
            "imageHeight": 972
        }
    ]
}
```
