## opx-linux-config
OpenSwitch Linux configuration

### Quick start
```bash
dbp shell -c 'cd opx-linux-config; ./build.bash'
```

Build different kernel versions by modifying the `VERSION` file. You can also change pieces of the version with `$UPSTREAM`, `$DEBIAN`, and `$OPX`. For example, build a kernel with the git commit in the version with
```bash
dbp shell -c "cd opx-linux-config; OPX='1~$(git rev-parse --short HEAD)' ./build.bash"
```

© 2018 Dell Inc. or its subsidiaries. All Rights Reserved.
