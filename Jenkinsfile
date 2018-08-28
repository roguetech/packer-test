node {
  environment {
    tool name: 'Packer', type: 'biz.neustar.jenkins.plugins.packer.PackerInstallation'
    def Packer = '/var/lib/jenkins/biz.neustar.jenkins.plugins.packer.PackerInstallation/Packer'
    def ESXihost = '192.168.121.130'
    def Workstation = '/var/lib/jenkins/workspace/packer-test'
  }
    stage ('Checkout') {
      checkout scm
    }
    stage('Build and Export') {
      echo 'Building and Exporting VMDK'
      sh '${Packer}packer build -force -var-file=variables.json packer.json '
    }

    stage('Openstack Image') {
      echo 'Create Openstack Image'
      sh 'openstack --insecure image set centos-latest --name centos-old'
      sh 'openstack --insecure image create --disk-format vmdk --file /var/lib/jenkins/workspace/packer-test/output-vmware-iso/packer-vmware-iso/packer-vmware-iso-disk1.vmdk centos-latest'
    }
    stage('Openstack Image Testing') {
      echo 'Testing Openstack Image'
    }
    stage('Cleanup') {
      echo 'Cleaning up'
    }
}
