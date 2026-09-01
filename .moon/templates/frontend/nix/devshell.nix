{
  perSystem = {pkgs, ...}: {
    shellPackages = with pkgs; [nodejs_26 pnpm];
  };
}
