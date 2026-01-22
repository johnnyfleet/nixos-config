# Easytag overlay - fix id3lib detection
final: prev: {
  easytag = prev.easytag.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ ["--with-id3lib"];
    buildInputs = (old.buildInputs or []) ++ [prev.id3lib];
  });
}
