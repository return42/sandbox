# SPDX-License-Identifier: AGPL-3.0-or-later
"""Python package metadata

.. _Building and Distributing Packages with Setuptools:
   https://setuptools.pypa.io/en/latest/userguide/index.html

About project metadata see `Declaring project metadata`_. About python packaging
see `Packaging Python Projects`_ and `Python Packaging Authority`_.

Include version number in the ``pyproject.toml`` file:

.. code:: toml

   [project]

   dynamic = ["version"]  # see [tool.setuptools.dynamic]

   [tool.setuptools.dynamic]
   version = {attr = "pysandbox.__pkginfo__.VERSION"}

Further read:

- `Packaging and distributing projects`_
- pythonwheels_
- setuptools_
- packaging_
- sdist_
- `bdist_wheel`_
- installing_

.. _Declaring project metadata:
`   https://packaging.python.org/en/latest/specifications/declaring-project-metadata/
.. _Python Packaging Authority:
    https://www.pypa.io
.. _Packaging Python Projects:
    https://packaging.python.org/en/latest/tutorials/packaging-projects/
.. _Packaging and distributing projects:
    https://packaging.python.org/guides/distributing-packages-using-setuptools/
.. _pythonwheels:
    https://pythonwheels.com/
.. _setuptools:
    https://setuptools.readthedocs.io/en/latest/setuptools.html
.. _packaging:
    https://packaging.python.org/guides/distributing-packages-using-setuptools/#packaging-and-distributing-projects
.. _sdist:
    https://packaging.python.org/guides/distributing-packages-using-setuptools/#source-distributions
.. _bdist_wheel:
    https://packaging.python.org/guides/distributing-packages-using-setuptools/#pure-python-wheels
.. _installing:
    https://packaging.python.org/tutorials/installing-packages/

"""

VERSION = "2023.9.23"
