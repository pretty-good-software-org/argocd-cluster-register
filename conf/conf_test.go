package conf

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConfigParse(t *testing.T) {
	os.Clearenv()
	env := map[string]string{
		"ROLE_ARN": "testing",
		//	"ROLEARN": "testing",
		"PROJECT": "test1,test2",
	}
	for k, v := range env {
		_ = os.Setenv(k, v)
	}

	c, err := ParseConfig()
	assert.Nil(t, err)

	assert.Equal(t, c.RoleARN, "testing", "RoleARN should be 'testing'")
	assert.Equal(t, c.Projects[0], "test1", "First project should be 'test1'")
	assert.Equal(t, c.Projects[1], "test2", "Second project should be 'test2'")
	assert.Equal(t, "argocd", c.ArgoNamespace, "ArgoNamespace should default to 'argocd'")
	assert.Equal(t, "capi-clusters", c.ClusterNamespace, "ClusterNamespace should default to 'capi-clusters'")
}

func TestConfigParseCustomNamespaces(t *testing.T) {
	os.Clearenv()
	env := map[string]string{
		"PROJECT":           "default",
		"ARGOCD_NAMESPACE":  "custom-argocd",
		"CLUSTER_NAMESPACE": "custom-clusters",
	}
	for k, v := range env {
		_ = os.Setenv(k, v)
	}

	c, err := ParseConfig()
	assert.Nil(t, err)

	assert.Equal(t, "custom-argocd", c.ArgoNamespace, "ArgoNamespace should be overridden")
	assert.Equal(t, "custom-clusters", c.ClusterNamespace, "ClusterNamespace should be overridden")
}
