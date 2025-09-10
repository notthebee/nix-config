{ ... }:
{
  services.snapraid = {
    enable = true;
    parityFiles = [ "/mnt/parity1/snapraid.parity" ];
    contentFiles = [
      "/mnt/data1/snapraid.content"
      "/mnt/data2/snapraid.content"
      "/mnt/data3/snapraid.content"
      "/mnt/data4/snapraid.content"
    ];
    dataDisks = {
      d1 = "/mnt/data1";
      d2 = "/mnt/data2";
      d3 = "/mnt/data3";
      d4 = "/mnt/data4";
    };
  };
}
