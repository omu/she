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
| Command       | Description                                                          |
| ------------- | -------------------------------------------------------------------- |
| available     | Return if program available                                          |
| bin install   | Install program to path                                              |
| bin use       | Use program by installing to a volatile path                         |
| contains      | Return if first argument found in remaining arguments                |
| deb add       | Add Debian repository                                                |
| deb install   | Install Debian packages                                              |
| deb missings  | Print missing packages among given packages                          |
| deb uninstall | Uninstall Debian packages                                            |
| deb update    | Update Debian package index                                          |
| deb using     | Use given official Debian distributions                              |
| dir enter     | Get src from URL and enter to the directory                          |
| dir inside    | Run command inside src                                               |
| dir install   | Install src into a source tree                                       |
| dir run       | Run src from URL                                                     |
| dir use       | Install src into a volatile source tree                              |
| enter         | Enter to directory/URL                                               |
| expired       | Return if any of the files expired                                   |
| file chogm    | Change owner, group and mode                                         |
| file copy     | Copy file/directory to destination creating all parents if necessary |
| file enter    | Enter file directory                                                 |
| file inside   | Run command inside directory                                         |
| file install  | Install src file to dst                                              |
| file link     | Link file/directory to dstination creating all parents if necessary  |
| file move     | Move file/directory to destination creating all parents if necessary |
| file run      | Run program                                                          |
| filetype any  | Assert any file type                                                 |
| filetype is   | Assert file type                                                     |
| filetype mime | Print mime type                                                      |
| git update    | Git pull if repository expired                                       |
| http any      | Assert HTTP response against any of the given codes                  |
| http get      | Get URL                                                              |
| http is       | Assert HTTP response against the given code                          |
| inside        | Enter to directory/URL and run command                               |
| must          | Ensure the given command succeeds                                    |
| os any        | Assert any OS feature                                                |
| os codename   | Print distribution codename                                          |
| os dist       | Print distribution name                                              |
| os is         | Assert OS feature                                                    |
| run           | Try to run file or URL                                               |
| self install  | Install self                                                         |
| self name     | Print self name                                                      |
| self path     | Print self path                                                      |
| self src      | Print self source                                                    |
| should        | Ignore error if the given command fails                              |
| text fix      | Append stdin content to the target file                              |
| text unfix    | Remove appended content                                              |
| ui bug        | Print bug message and exit failure                                   |
| ui bye        | Print message and exit success                                       |
| ui calling    | Print message and run command                                        |
| ui cry        | Print warning message                                                |
| ui die        | Print error message and exit failure                                 |
| ui getting    | Print message indicating a download and run command                  |
| ui hmm        | Print info message                                                   |
| ui notok      | Print not ok message                                                 |
| ui ok         | Print ok message                                                     |
| ui running    | Print a busy message run command                                     |
| ui say        | Print message on stderr                                              |
| url any       | Assert URL type                                                      |
| url is        | Assert URL type                                                      |
| url parse     | Parse URL                                                            |
| version       | Return version                                                       |
| virt any      | Assert any of the virtualization types                               |
| virt is       | Assert virtualization type                                           |
| virt which    | Detect virtualization type                                           |
| web install   | Install file from web                                                |
| web run       | Run program through web                                              |
| zip unpack    | Unpack compressed file                                               |
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
