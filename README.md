Shell extensions
================

`_` commands
------------

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
| enter         | Enter to url                                                         |
| expired       | Return if any of the files expired                                   |
| file chogm    | Change owner, group and mode                                         |
| file copy     | Copy file/directory to destination creating all parents if necessary |
| file enter    | Enter file directory                                                 |
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
| must          | Ensure the given command succeeds                                    |
| os any        | Assert any OS feature                                                |
| os codename   | Print distribution codename                                          |
| os dist       | Print distribution name                                              |
| os is         | Assert OS feature                                                    |
| run           | Try to run any file or url                                           |
| self install  | Install self                                                         |
| self name     | Print self name                                                      |
| self path     | Print self path                                                      |
| self src      | Print self source                                                    |
| self version  | Print self version                                                   |
| should        | Ignore error if the given command fails                              |
| src enter     | Get src from url and enter to the directory                          |
| src install   | Install src into a source tree                                       |
| src run       | Run src from url                                                     |
| src use       | Install src into a volatile source tree                              |
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
| virt any      | Assert any of the virtualization types                               |
| virt is       | Assert virtualization type                                           |
| virt which    | Detect virtualization type                                           |
| web install   | Install file from web                                                |
| web run       | Run program through web                                              |
| zip unpack    | Unpack compressed file                                               |
<!-- _ end -->

`t` commands
------------

<!-- t begin -->
| Command       | Description                                                          |
| ------------- | -------------------------------------------------------------------- |
| t err         | Assert failed command outputs                                        |
| t fail        | Return failure                                                       |
| t go          | Run all test suites defined so far                                   |
| t is          | Assert actual value equals to the expected                           |
| t isnt        | Assert got value not equals to the expected                          |
| t like        | Assert got value matches with the expected                           |
| t notok       | Assert command fails                                                 |
| t ok          | Assert command succeeds                                              |
| t out         | Assert successful command outputs                                    |
| t pass        | Return success                                                       |
| t temp        | Create and chdir to temp directory                                   |
| t unlike      | Assert got value not matches with the expected                       |
<!-- t end -->
