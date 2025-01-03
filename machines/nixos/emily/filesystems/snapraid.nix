{ ... }:
{
  services.snapraid = {
    enable = true;
    parityFiles = [
      "/mnt/parity1/snapraid.parity"
    ];
    contentFiles = [
      "/mnt/data1/snapraid.content"
      "/mnt/data2/snapraid.content"
    ];
    dataDisks = {
      d1 = "/mnt/data1";
      d2 = "/mnt/data2";
    };
  };
}
