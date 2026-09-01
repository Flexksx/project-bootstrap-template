{
  perSystem = {pkgs, ...}: {
    shellPackages = with pkgs; [nodejs_24 pnpm];
  };
}
