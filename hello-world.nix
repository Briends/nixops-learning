{ config, pkgs, lib, credentials, resources, ... }: {

  # Ensure the networking is enabled
  networking.firewall.enable = false;
  networking.hostName = "hello-world-machine"; # Define your hostname
  
  # https://github.com/nix-community/nixops-gce/blob/master/examples/simple-web-server/nixops.nix
  deployment.targetEnv = "gce"; 

  # Instance Configuration
  deployment.gce = credentials // {
    region = "europe-west1-b";
    instanceType = "n1-standard-2";
    network = resources.gceNetworks.web;
    scheduling.preemptible = true;
  };

  # Define the services
  services.httpd = {
    enable = true;
    adminAddr = "admin@example.com";
    documentRoot = "/etc/www";
  };

  # Create a simple index.html file to serve
  environment.etc."www/index.html".text = ''
    <html>
    <head><title>Hello World</title></head>
    <body><h1>Hello World!</h1></body>
    </html>
  '';

  networking.firewall.allowedTCPPorts = [ 80 ];

  # This is a simple, declarative way to ensure that
  # the httpd service is always running
  systemd.services.httpd.wantedBy = [ "multi-user.target" ];
}