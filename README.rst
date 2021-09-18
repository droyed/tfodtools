Tensorflow Object Detection Tools
=================================

|Py-Versions| |OS| |License|

This repository is conceived with the idea of simplifying [`tensorflow objection detection workflow`](https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/training.html) to minimize the hassles of setting up various components and maximizing automation between them. It also extends to incoporate a mobile-based inferencing of the trained models. Thus, this could work as an `end-to-end toolkit` solution for a tensorflow based objection detection project.

Steps
-----

.. code-block:: console

    $ cd shell_scripts

**I.** Setup python virtual environment :

.. code-block:: console

    $ bash setup_tfODenv.sh

This will interactively setup the environment and will be a one-time process. It also sets up a config file that facilitates the next steps. So, training on new data or with new models would re-use this setup.

Before proceeding with next step, let's make sure we have the input data in the required format. It's explored in detail at `Tensorflow object detection data setup - Setup images and xmls <https://github.com/droyed/datatools/blob/main/docs/source/tfod_setup_imgs_xmls.md>`_.

**II.** Setup data and training :

.. code-block:: console

    $ bash setup_data_train.sh

This will setup everything needed for training, start it and also dynamically create `save_model.sh` and `create_mobile_optimized_model.sh` that are scripts needed later on for inferencing.

**III.** Once done with training, we can save this model with :

.. code-block:: console

    $ bash save_model.sh

The saved model could then be loaded into tensorflow environment for inferencing.

**IV. (Optional)** We can also create mobile optimized version for inferencing on mobile devices with :

.. code-block:: console

    $ bash create_mobile_optimized_model.sh

This will create `model.json` and `shard` files :

.. code-block:: console

    .
    ├── group1-shard1of3.bin
    ├── group1-shard2of3.bin
    ├── group1-shard3of3.bin
    └── model.json


`Setup mobile inference <https://github.com/droyed/tfodtools/blob/main/docs/source/setup_mobile_inference.md>`_ discusses a setup workflow on using these files for a mobile based inferencing.

**Note :** For now, this workflow works as a single class/object detection solution.



.. |Py-Versions| image:: https://img.shields.io/badge/Python-3.6+-blue
   :target: https://github.com/droyed/tfodtools

.. |OS| image:: https://img.shields.io/badge/Platform-%E2%98%AFLinux-9cf
   :target: https://github.com/droyed/tfodtools

.. |License| image:: https://img.shields.io/badge/license-MIT-green
   :target: https://raw.githubusercontent.com/droyed/tfodtools/master/LICENSE

