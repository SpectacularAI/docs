# Docs website

A static website hosting the documentation of the Spectacular AI SDK
see also https://github.com/SpectacularAI/sdk-examples.

## PDF guides

 * [Calibration manual](https://spectacularai.github.io/docs/pdf/calibration_manual.pdf)
 * [AprilTag instructions](https://spectacularai.github.io/docs/pdf/april_tag_instructions.pdf)
 * [OAK-D Fisheye calibration instructions](https://spectacularai.github.io/docs/pdf/oak_fisheye_calibration_instructions.pdf)
 * [OAK-D + u-blox GNSS-VIO instructions](https://spectacularai.github.io/docs/pdf/GNSS-VIO_OAK-D_Python.pdf)

## Updating

Install requirements:

    pip install -r requirements.txt

Run this script (see contents for more details)

    ./import-python-docs.sh MAJOR.MINOR

where MAJOR.MINOR is the new/latest SDK version without patch version or and "v".
Then check

    git status

If there are changes, commit and push them.

# Spectacular AI demo GIFs

(also hosted on the same site)

See https://github.com/SpectacularAI/sdk-examples for the example
codes which were used to create these videos.

### Demo GIFs

 * [SDK install demo](gif/pip-install.gif)
 * [Spatial AI](gif/spatial-ai.gif)
 * [OAK-D fast NeRF](gif/oak-d-nerf.gif)
 * [Retro AR](gif/retro-ar.gif)
 * [HybVIO EuRoC](gif/HybVIO.gif)
