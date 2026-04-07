package main

import (
	"os"

	"github.com/cert-manager/cert-manager/pkg/acme/webhook/cmd"
	"github.com/emulatorchen/cert-manager-webhook-freemyip/freemyip"
	"k8s.io/klog/v2"
)

func main() {
	groupName := os.Getenv("GROUP_NAME")
	if groupName == "" {
		klog.Fatal("GROUP_NAME must be specified")
	}

	// Register the freemyip DNS solver with the webhook serving library.
	// The Name() method on the solver disambiguates it within the group.
	cmd.RunWebhookServer(groupName, freemyip.NewSolver())
}
