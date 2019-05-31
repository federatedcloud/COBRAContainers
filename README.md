## Requirements

* MATLAB 2017a+ (tested; but must already be installed by another Linux Distribution)
* Docker, if not using NixOS


## Running the environment

### Docker

In short:

1. `source build.sh` or `source pull.sh`.
2. `./run.sh`
3. Proceed to the Nix instructions below

### Nix

#### Each time

3. `cd ~/workspace/COBRAContainers/nix/shells/MATLAB`
4. `nix-shell default.nix`
5. `matlab -glnxa64`

Alternatively, append `-nodesktop -nodisplay` to the `matlab** command
when running in the terminal.

**Important**: You must execute the `nix-shell default.nix` command
from the same directory specified above, as that directory
contains another script that must be run.

If you are wanting a single script to do all this for you, do e.g.:

```bash
#!/usr/bin/env bash
cd /home/bebarker/workspace/COBRAContainers/nix/shells/MATLAB/ && \
  nix-shell default.nix --run "matlab -glnxa64"
```

You can omit using the script if you have other ways to change the working
directory, in e.g. desktop icon-based launchers.

#### One-time-only for gurobi

In the nix-shell enviroment:

0. `mkdir -p ~/Documents/MATLAB`
1. `cp $GUROBI_HOME/examples/matlab/mip1.m ~/Documents/MATLAB/`
2. `echo $GUROBI_HOME`

In matlab (started from the nix-shell environment)

2. `cd` to that directory (obtained from  `echo $GUROBI_HOME`) in MATLAB, then `cd matlab`
3. `gurobi_setup`
4. `cd ~/Documents/MATLAB/`
5. `mip1`

You should see a solution printed out.

