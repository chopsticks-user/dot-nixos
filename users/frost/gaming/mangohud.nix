{...}: {
  programs.mangohud = {
    enable = true;
    settings = {
      fps = true;
      cpu_temp = true;
      gpu_temp = true;
      ram = true;
      vram = true;
      frame_timing = true;
    };
  };
}
