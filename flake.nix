{
  description = "CLI client for the deSEC DNS API";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      version = self.shortRev or self.dirtyShortRev or "dev";
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.buildGoModule {
            pname = "desec-cli";
            inherit version;

            src = ./.;
            vendorHash = "sha256-BFwrVScgaxO9dc18j9wfRps1d9PgNpDEFIzTxIY9z1o=";
            subPackages = [ "." ];

            ldflags = [
              "-s"
              "-w"
              "-X"
              "github.com/swagner-de/desec-cli/cmd.version=${version}"
              "-X"
              "github.com/swagner-de/desec-cli/cmd.commit=${self.rev or "unknown"}"
              "-X"
              "github.com/swagner-de/desec-cli/cmd.date=1970-01-01T00:00:00Z"
            ];

            meta = {
              description = "CLI client for the deSEC DNS API";
              homepage = "https://github.com/swagner-de/desec-cli";
              license = pkgs.lib.licenses.mit;
              mainProgram = "desec-cli";
              platforms = pkgs.lib.platforms.unix;
            };
          };
        });

      overlays.default = final: prev: {
        desec-cli = self.packages.${final.system}.default;
      };

      checks = forAllSystems (system: {
        default = self.packages.${system}.default;
      });
    };
}
