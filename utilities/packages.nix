{ ... }:
{
  mkOverlay =
    name: args:
    (final: prev: {
      ${name} = final.callPackage ../overlays/${name}/package.nix ({ inherit prev; } // args);
    });

  mkSpecializedPackage =
    upstream: system: overlays:
    import upstream {
      inherit system overlays;
    };
}
