<?php

class IndexController extends pm_Controller_Action
{
    /**
     * Entry point for the extension page.
     */
    public function indexAction()
    {
        $this->view->pageTitle = 'Flowtriq DDoS Detection';

        // Gather ftagent status
        $this->view->serviceStatus = $this->getServiceStatus();
        $this->view->agentVersion  = $this->getAgentVersion();
        $this->view->lastHeartbeat = $this->getLastHeartbeat();
        $this->view->incidentCount = $this->getIncidentCount();

        // Process control actions
        $action = $this->getRequest()->getParam('service_action');
        if ($action && in_array($action, ['start', 'stop', 'restart'], true)) {
            $this->handleServiceAction($action);
        }
    }

    /**
     * Check whether ftagent systemd service is running.
     */
    private function getServiceStatus()
    {
        $output = [];
        $code   = 0;
        exec('systemctl is-active ftagent 2>/dev/null', $output, $code);

        if ($code === 0 && isset($output[0]) && trim($output[0]) === 'active') {
            return 'running';
        }

        return 'stopped';
    }

    /**
     * Get installed ftagent version.
     */
    private function getAgentVersion()
    {
        $output = [];
        $code   = 0;
        exec('ftagent --version 2>/dev/null', $output, $code);

        if ($code === 0 && !empty($output[0])) {
            return trim($output[0]);
        }

        return 'Unknown';
    }

    /**
     * Read the last heartbeat timestamp from ftagent status.
     */
    private function getLastHeartbeat()
    {
        $output = [];
        $code   = 0;
        exec('ftagent --status --json 2>/dev/null', $output, $code);

        if ($code === 0 && !empty($output)) {
            $json = json_decode(implode('', $output), true);
            if (isset($json['last_heartbeat'])) {
                return $json['last_heartbeat'];
            }
        }

        return 'N/A';
    }

    /**
     * Get the number of recent incidents from ftagent.
     */
    private function getIncidentCount()
    {
        $output = [];
        $code   = 0;
        exec('ftagent --status --json 2>/dev/null', $output, $code);

        if ($code === 0 && !empty($output)) {
            $json = json_decode(implode('', $output), true);
            if (isset($json['incidents_24h'])) {
                return (int) $json['incidents_24h'];
            }
        }

        return 0;
    }

    /**
     * Start, stop, or restart the ftagent service.
     */
    private function handleServiceAction($action)
    {
        $allowed = ['start', 'stop', 'restart'];
        if (!in_array($action, $allowed, true)) {
            $this->_status->addError('Invalid action.');
            return;
        }

        $output = [];
        $code   = 0;
        exec("systemctl {$action} ftagent 2>&1", $output, $code);

        if ($code === 0) {
            $this->_status->addMessage("ftagent service: {$action} successful.");
        } else {
            $this->_status->addError(
                "Failed to {$action} ftagent: " . implode("\n", $output)
            );
        }

        // Refresh status after action
        $this->view->serviceStatus = $this->getServiceStatus();

        // Redirect back to avoid form resubmission
        $this->_helper->redirector('index');
    }
}
