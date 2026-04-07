package freemyip

import (
	"encoding/json"
	"fmt"

	cmmeta "github.com/cert-manager/cert-manager/pkg/apis/meta/v1"
	extapi "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
)

// Config holds the per-issuer configuration decoded from the ClusterIssuer's
// webhook solver stanza.  Only non-sensitive fields belong here; credentials
// are fetched at runtime from a Kubernetes Secret referenced by APITokenSecretRef.
type Config struct {
	// APITokenSecretRef is a reference to the Secret that contains the
	// freemyip API token under the specified key.
	APITokenSecretRef cmmeta.SecretKeySelector `json:"apiTokenSecretRef"`
}

// loadConfig decodes the raw JSON configuration supplied by cert-manager into
// a typed Config struct.
func loadConfig(cfgJSON *extapi.JSON) (Config, error) {
	cfg := Config{}
	if cfgJSON == nil {
		return cfg, nil
	}
	if err := json.Unmarshal(cfgJSON.Raw, &cfg); err != nil {
		return cfg, fmt.Errorf("error decoding solver config: %v", err)
	}
	return cfg, nil
}
