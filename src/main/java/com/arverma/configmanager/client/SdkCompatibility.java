package com.arverma.configmanager.client;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Declares which Config Manager API contract this SDK build was generated from.
 * SDK semver ({@link #sdkVersion()}) is independent of the OpenAPI contract version.
 */
public final class SdkCompatibility {

  private static final Properties METADATA = loadMetadata();

  private SdkCompatibility() {}

  /** Maven {@code revision} of this SDK artifact (e.g. {@code 0.2.0}). */
  public static String sdkVersion() {
    return require("sdk.version");
  }

  /** {@code info.version} from the OpenAPI spec this SDK was generated against. */
  public static String openApiVersion() {
    return require("openapi.api.version");
  }

  /** Git ref (tag, branch, or commit) of the upstream OpenAPI spec. */
  public static String openApiSpecRef() {
    return require("openapi.spec.ref");
  }

  /** Upstream repository containing {@code api/openapi.yaml}. */
  public static String openApiSpecRepo() {
    return require("openapi.spec.repo");
  }

  /** Lowest Config Manager server version this SDK is expected to work with. */
  public static String minServerVersion() {
    return require("server.version.min");
  }

  private static String require(String key) {
    String value = METADATA.getProperty(key);
    if (value == null || value.isBlank()) {
      throw new IllegalStateException("Missing SDK metadata property: " + key);
    }
    return value;
  }

  private static Properties loadMetadata() {
    Properties props = new Properties();
    try (InputStream in =
        SdkCompatibility.class.getResourceAsStream("/META-INF/config-manager-sdk.properties")) {
      if (in == null) {
        throw new IllegalStateException("Missing /META-INF/config-manager-sdk.properties");
      }
      props.load(in);
    } catch (IOException e) {
      throw new IllegalStateException("Failed to load SDK metadata", e);
    }
    return props;
  }
}
