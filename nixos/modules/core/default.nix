# Core system configuration shared by every host
{ ... }:

{
  imports = [
    ./boot.nix
    ./nix.nix
    ./users.nix
    ./locale.nix
  ];
}
