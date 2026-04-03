{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      user = {
	name = "chopsticks-user";
	email = "frostyfrost273@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.gh = {
    enable = true;
    settings = {};
  };
}
