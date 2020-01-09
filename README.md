<!-- markdownlint-disable MD041 -->
[![ActionsI](https://github.com/omu/she/workflows/build/badge.svg)](https://github.com/omu/she/actions "Github actions")
[![Seed](https://omu.sh/assets/badge/seed.svg)](https://omu.sh "Seed project")
<!-- markdownlint-enable MD041 -->

Shell extensions
================

Shell extensions (aka "she") consist of utility functions, which are bundled in executable scripts, developed for use in
**Bash** scripts.  The `_` script consists of general-purpose helpers; where as the `t` script consists of test helpers,
that can be used in shell tests.  These functions are consumed as the recommended method as follows.

- `_` bundle

  ```sh
  . <(_)

  _ COMMAND... [OPTIONS]... [ARGUMENTS]...
  ```

- `t` bundle

  ```sh
  . <(t) [DOSYA]...

  t COMMAND ARGUMENT -- MESSAGE

  t go
  ```

`_`
---

<!-- _ begin -->
| Command       | Description                                           |
| ------------- | ----------------------------------------------------- |
| available     | Return if program available                           |
| bin install   | Install program to path                               |
| bin use       | Use program by installing to a volatile path          |
| contains      | Return if first argument found in remaining arguments |
| deb add       | Add Debian repository                                 |
| deb install   | Install Debian packages                               |
| deb missings  | Print missing packages among given packages           |
| deb uninstall | Uninstall Debian packages                             |
| deb update    | Update Debian package index                           |
| deb using     | Use given official Debian distributions               |
| etc get       | Get persistent variable(s)                            |
| etc reset     | Reset persistent variable(s)                          |
| etc set       | Set persistent variable(s)                            |
| expired       | Return if any of the files expired                    |
| file chmog    | Change owner, group and mode                          |
| file run      | Run program                                           |
| filetype any  | Assert any file type                                  |
| filetype is   | Assert file type                                      |
| filetype mime | Print mime type                                       |
| git update    | Git pull if repository expired                        |
| http get      | Get URL                                               |
| http ok       | Assert HTTP response is ok                            |
| must          | Ensure the given command succeeds                     |
| os any        | Assert any OS feature                                 |
| os is         | Assert OS feature                                     |
| os which      | Print OS feature                                      |
| run           | Run a local or remote file with optional environment  |
| self install  | Install self                                          |
| self name     | Print self name                                       |
| self path     | Print self path                                       |
| self src      | Print self source                                     |
| should        | Ignore error if the given command fails               |
| src enter     | Fetch and chdir to source                             |
| src install   | Fetch and instal source into a known source tree      |
| src with      | Fetch source and run given command inside it          |
| text fix      | Append stdin content to the target file               |
| text unfix    | Remove appended content                               |
| ui bug        | Print bug message and exit failure                    |
| ui bye        | Print message and exit success                        |
| ui calling    | Print message and run command                         |
| ui cry        | Print warning message                                 |
| ui die        | Print error message and exit failure                  |
| ui getting    | Print message indicating a download and run command   |
| ui hmm        | Print info message                                    |
| ui notok      | Print not ok message                                  |
| ui ok         | Print ok message                                      |
| ui running    | Print a busy message run command                      |
| ui say        | Print message on stderr                               |
| url dump      | Parse and dump URL                                    |
| url is        | Assert URL type                                       |
| var get       | Get variable(s)                                       |
| var reset     | Reset variable(s)                                     |
| var set       | Set variable(s)                                       |
| version       | Return version                                        |
| virt any      | Assert any of the virtualization types                |
| virt is       | Assert virtualization type                            |
| virt which    | Detect virtualization type                            |
| zip unpack    | Unpack compressed file                                |
<!-- _ end -->

`t`
---

<!-- t begin -->
| Command | Description                                    |
| ------- | ---------------------------------------------- |
| err     | Assert failed command outputs                  |
| fail    | Return failure                                 |
| go      | Run all test suites defined so far             |
| is      | Assert actual value equals to the expected     |
| isnt    | Assert got value not equals to the expected    |
| like    | Assert got value matches with the expected     |
| notok   | Assert command fails                           |
| ok      | Assert command succeeds                        |
| out     | Assert successful command outputs              |
| pass    | Return success                                 |
| temp    | Create and chdir to temp directory             |
| unlike  | Assert got value not matches with the expected |
| version | Return version                                 |
<!-- t end -->
