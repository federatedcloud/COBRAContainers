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

3. `cd ~/workspace/COBRAContainers/nix/shells/MATLAB`
4. `nix-shell default.nix`
5. `matlab -glnxa64`
