# Verifying the Package Release

This package is published as an OCI artifact, signed with Sigstore [Cosign](https://docs.sigstore.dev/cosign/overview), and associated with a [SLSA Provenance](https://slsa.dev/provenance) attestation.

Using `cosign`, you can display the supply chain security related artifacts for the `ghcr.io/kadras-io/package-for-contour` images. Use the specific digest you'd like to verify.

```shell
cosign tree ghcr.io/kadras-io/package-for-contour
```

The result:

```shell
📦 Supply Chain Security Related artifacts for an image: ghcr.io/kadras-io/package-for-contour
└── 💾 Attestations for an image tag: ghcr.io/kadras-io/package-for-contour:sha256-199401260a26831f6cefb5ace643b55278e77b5cf889b7ccd84f8f660d84679b.att
   └── 🍒 sha256:35330e6f6fdf0f9dfc8b048de5ad97b8c44091400ec1989b65db56232fe9134e
└── 🔐 Signatures for an image tag: ghcr.io/kadras-io/package-for-contour:sha256-199401260a26831f6cefb5ace643b55278e77b5cf889b7ccd84f8f660d84679b.sig
   └── 🍒 sha256:8aa673f21bfb8836b8f81c6ca5c583afd38b73a5c0535f4ec9b2e6c0304201b3
```

You can verify the signature and its claims:

```shell
cosign verify \
   --certificate-identity-regexp https://github.com/kadras-io \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/package-for-contour | jq
```

You can also verify the SLSA Provenance attestation associated with the image.

```shell
cosign verify-attestation --type slsaprovenance \
   --certificate-identity-regexp https://github.com/slsa-framework \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/package-for-contour | jq .payload -r | base64 --decode | jq
```
