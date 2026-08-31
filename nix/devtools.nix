{
  perSystem = {pkgs, ...}: {
    shellPackages = with pkgs; [just alejandra lefthook rumdl];
  };
}
