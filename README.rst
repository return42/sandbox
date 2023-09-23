===================
My personal sandbox
===================

.. contents::
   :depth: 2
   :local:
   :backlinks: entry

Before you start, you might want to set up a `Runtime Management`_.

Developer Environment
=====================

To set up a developer environment once:

.. code:: sh

   $ make env.build

To start a command (``bash``) in sandbox's environment:

.. code:: sh

   $ ./prj cmd bash

Sandbox Projects
================

To see what projects (command lines) are available in the sandbox:

.. code:: sh

   $ ./prj cmd pysandbox prj --help
   Usage: pysandbox prj [OPTIONS] COMMAND [ARGS]...

     comand line of sandbox projects

   Options:
    --help  Show this message and exit.

   Commands:
     ...


Runtime Management
==================

.. _asdf: https://asdf-vm.com/
.. _download asdf: https://asdf-vm.com/guide/getting-started.html#_2-download-asdf
.. _install asdf: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
.. _install plugins: https://asdf-vm.com/guide/getting-started.html#install-the-plugin
.. _Fallback to System Version: https://asdf-vm.com/manage/versions.html#fallback-to-system-version

The runtimes are managed with asdf and are activated in this project via the
`.tool-versions <.tool-versions>`_: Its recommended to manage runtime versions
by asdf_, if you have not installed, `download asdf`_ and `install asdf`_.

.. code:: bash

   $ git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch <version>
   $ echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
   $ echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc

Start a new shell and try to `install plugins`_:

.. code:: bash

   $ asdf plugin-list-all | grep -E '(golang|python|nodejs|shellcheck).git'
   golang                        https://github.com/asdf-community/asdf-golang.git
   nodejs                        https://github.com/asdf-vm/asdf-nodejs.git
   python                        https://github.com/danhper/asdf-python.git
   shellcheck                    https://github.com/luizm/asdf-shellcheck.git

   $ asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
   $ asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
   $ asdf plugin add python https://github.com/danhper/asdf-python.git
   $ asdf plugin add shellcheck https://github.com/luizm/asdf-shellcheck.git

Each plugin has dependencies, to compile runtimes visit the URLs from above and
look out for the dependencies you need to install on your OS, on Debian for the
runtimes listed above you will need:

.. code:: bash

  $ sudo apt update
  $ sudo apt install \
         dirmngr gpg curl gawk coreutils build-essential libssl-dev zlib1g-dev \
         libbz2-dev libreadline-dev libsqlite3-dev \
         libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

With dependencies installed you can install/compile runtimes:

.. code:: bash

  $ asdf install golang latest
  $ asdf install nodejs latest
  $ asdf install python latest
  $ asdf install shellcheck latest

Python will be compiled and will take a while.

In the repository the version is defined in `.tool-versions`_. Outside the
repository, its recommended that the runtime should use the versions of the OS
(`Fallback to System Version`_) / if not already done register the system
versions global:

.. code:: bash

   $ cd /
   $ asdf global golang system
   $ asdf global nodejs system
   $ asdf global python system
   $ asdf global shellcheck system



