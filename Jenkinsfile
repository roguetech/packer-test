Workstation = "/var/lib/jenkins/workspace/packer-test"
Packer = '/var/lib/jenkins/biz.neustar.jenkins.plugins.packer.PackerInstallation/Packer'
node {
  environment {
    tool name: 'Packer', type: 'biz.neustar.jenkins.plugins.packer.PackerInstallation'
  }
    stage ('Checkout') {
      checkout scm
    }
    stage('Build and Export') {
      echo 'Building and Exporting VMDK'
     // sh '${Packer}packer build -force -var-file=variables.json packer.json '
    }

    stage('Openstack Image') {
      echo 'Create Openstack Image'
      //echo "${Date}"
      echo Workstation
      sh 'echo ${Workstation}'
      //sh 'openstack --insecure image set centos-latest --name centos-${date}'
      //sh 'openstack --insecure image create --disk-format vmdk --file /var/lib/jenkins/workspace/packer-test/output-vmware-iso/packer-vmware-iso/packer-vmware-iso-disk1.vmdk centos-latest'
    }
    stage('Openstack Image Testing') {
      echo 'Testing Openstack Image'
    }
    stage('Cleanup') {
      echo 'Cleaning up'
    }
}
