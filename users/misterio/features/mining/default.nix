{
  services.ethminer = {
    enable = true;
    wallet = "0x16EeE21f85c06D3B983533b32Eef82d963d24f9a";
    pool = "eth-br.flexpool.io";
    port = 5555;
    rig = "misterio";
  };
  home.sessionVariables.OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors/";
}
