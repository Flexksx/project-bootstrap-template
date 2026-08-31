{
  perSystem = {pkgs, ...}: {
    shellPackages = [pkgs.uv];
  };
}
