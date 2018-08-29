import java.text.SimpleDateFormat
dateFormat = new SimpleDateFormat("yyyyMMddHHmm")
date = new Date()
newdate = (dateFormat.format(date))
Workstation = "/var/lib/jenkins/workspace/packer-test"
Packer = '/var/lib/jenkins/tools/biz.neustar.jenkins.plugins.packer.PackerInstallation/packer'
VMDKLocation = '/var/lib/jenkins/workspace/packer-test/output-vmware-iso/packer-vmware-iso'

pipeline {
  agent any
  options {
    buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
  }
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
      //  sh "'$Packer'/packer build -force -var-file=variables.json packer.json"
      }
    }

    stage('Openstack Image') {
      steps {
        echo 'Create Openstack Image'
       // sh "openstack --insecure image set centos-latest --name centos-'$newdate'"
       // sh "openstack --insecure image create --disk-format vmdk --file '$VMDKLocation'/packer-vmware-iso-disk1.vmdk centos-latest"
      }
    }
    stage('Build Openstack Test Image') {
      steps {
        echo 'Testing Openstack Image'
      }
    }
    stage('Testing Image'){
      steps {
        echo 'Testing Image'
      }
    }
    stage('Deploy to Artifactory'){
      steps{
        echo 'Pushing to Artifactory'
      }
    }
    post {
      cleanup {
        echo 'Cleaning Up'
      }
      }
    }
  }
}
