Shell extensions
================

`_` commands
------------

<!-- _ begin -->
| Command       | Description                                         |
| ------------- | --------------------------------------------------- |
| available     | Return if program available                         |
| bin install   | Install program to path                             |
| bin use       | Use program by installing to a volatile path        |
| bug           | Print bug message and exit failure                  |
| cry           | Print warning message                               |
| deb add       | Add Debian repository                               |
| deb install   | Install Debian packages                             |
| deb missings  | Print missing packages among given packages         |
| deb uninstall | Uninstall Debian packages                           |
| deb update    | Update Debian package index                         |
| deb using     | Use given official Debian distributions             |
| die           | Print error message and exit failure                |
| enter         | Get src from url and enter to the directory         |
| expired       | Return if any of the files expired                  |
| file install  | Install file from URL                               |
| filetype any  | Assert any file type                                |
| filetype is   | Assert file type                                    |
| filetype mime | Print mime type                                     |
| http any      | Assert HTTP response against any of the given codes |
| http get      | Get URL                                             |
| http is       | Assert HTTP response against the given code         |
| must          | Ensure the given command succeeds                   |
| os any        | Assert any OS feature                               |
| os codename   | Print distribution codename                         |
| os dist       | Print distribution name                             |
| os is         | Assert OS feature                                   |
| run           | Try to run any file or url                          |
| say           | Print message on stderr                             |
| self install  | Install self                                        |
| self name     | Print self name                                     |
| self path     | Print self path                                     |
| self src      | Print self source                                   |
| self version  | Print self version                                  |
| should        | Ignore error if the given command fails             |
| src install   | Install src into a source tree                      |
| src use       | Install src into a volatile source tree             |
| temp inside   | Execute command in temp dir                         |
| text fix      | Append stdin content to the target file             |
| text unfix    | Remove appended content                             |
| ui calling    | Print message and run command                       |
| ui getting    | Print message indicating a download and run command |
| ui info       | Print info message                                  |
| ui notok      | Print not ok message                                |
| ui ok         | Print ok message                                    |
| ui running    | Print a busy message run command                    |
| unzip         | Unpack compressed file                              |
| url any       | Assert URL type                                     |
| url is        | Assert URL type                                     |
| virt any      | Assert any of the virtualization types              |
| virt is       | Assert virtualization type                          |
| virt which    | Detect virtualization type                          |
<!-- _ end -->

`t` commands
------------

<!-- t begin -->
| Command       | Description                                         |
| ------------- | --------------------------------------------------- |
| err           | Assert failed command outputs                       |
| fail          | Return failure                                      |
| go            | Run all test suites defined so far                  |
| is            | Assert actual value equals to the expected          |
| isnt          | Assert got value not equals to the expected         |
| like          | Assert got value matches with the expected          |
| notok         | Assert command fails                                |
| ok            | Assert command succeeds                             |
| out           | Assert successful command outputs                   |
| pass          | Return success                                      |
| temp          | Create and chdir to temp directory                  |
| unlike        | Assert got value not matches with the expected      |
<!-- t end -->
