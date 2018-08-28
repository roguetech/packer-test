node {
  environment {
    tool name: 'Packer', type: 'biz.neustar.jenkins.plugins.packer.PackerInstallation'
    def Packer = '/var/jenkins_home/biz.neustar.jenkins.plugins.packer.PackerInstallation/Packer'
    def ESXihost = '192.168.121.130'
    def Workstation = '/var/jenkins_home/workspace/packer-test'
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
      openstack --insecure image set centos-latest --name centos-old
      openstack --insecure image create --disk-format vmdk --file '${Workstation}'/output-vmware-iso/packer-vmware-iso/packer-vmware-iso-disk1.vmdk centos-latest
    }
    stage('Openstack Image Testing') {
      echo 'Testing Openstack Image'
    }
    stage('Cleanup') {
      echo 'Cleaning up'
    }
}
