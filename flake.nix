{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    jupyterWith.url = "github:tweag/jupyterWith";
  };

  outputs = { nixpkgs, flake-utils, jupyterWith, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = nixpkgs.lib.attrValues jupyterWith.overlays;
        };
        iPython = pkgs.kernels.iPythonWith {
          name = "Python-env";
          packages = p:
            with p; [
              numpy
              pandas
              scikit-learn
              matplotlib
              seaborn
            ];
          ignoreCollisions = true;
        };
        jupyterEnvironment = pkgs.jupyterlabWith {
          kernels = [ iPython ];
          extraPackages = p: [ p.wget2 ];
        };
      in rec {
        apps = rec {
          jupyterLab = {
            type = "app";
            program = "${jupyterEnvironment}/bin/jupyter-lab";
          };
          default = jupyterLab;
        };
        devShells.default = jupyterEnvironment.env;
      });
}
