import java.text.SimpleDateFormat
Workstation = "/var/lib/jenkins/workspace/packer-test"
Packer = '/var/lib/jenkins/tools/biz.neustar.jenkins.plugins.packer.PackerInstallation/packer'
VMDKLocation = '/var/lib/jenkins/workspace/packer-test/output-vmware-iso/packer-vmware-iso'
pipeline {
  agent any
  environment {
    Packer = tool name: 'Packer', type: 'biz.neustar.jenkins.plugins.packer.PackerInstallation'
  }
  stages{
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build and Export') {
      steps {
        echo 'Building and Exporting VMDK'
        sh "'$Packer'/packer build -force -var-file=variables.json packer.json"
      }
    }

    stage('Openstack Image') {
      steps {
        def dateFormat = new SimpleDateFormat("yyyyMMddHHmm")
        def date = new Date()
        newdate = (dateFormat.format(date))
      }
      steps {
        echo 'Create Openstack Image'
        sh "openstack --insecure image set centos-latest --name centos-'$newdate'"
        sh "openstack --insecure image create --disk-format vmdk --file '$VMDKLocation'/packer-vmware-iso-disk1.vmdk centos-latest"
      }
    }
    stage('Openstack Image Testing') {
      steps {
        echo 'Testing Openstack Image'
      }
    }
    stage('Cleanup') {
      steps {
        echo 'Cleaning up'
      }
    }
  }
}
