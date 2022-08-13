{
  # TODO: start server declaratively
  networking.firewall = {
    # Minecraft
    allowedTCPPorts = [ 25565 ];
    # Query and Voice chat
    allowedUDPPorts = [ 25565 24454 ];
  };
}
