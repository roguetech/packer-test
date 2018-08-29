//import java.text.SimpleDateFormat
//dateFormat = new SimpleDateFormat("yyyyMMddHHmm")
//date = new Date()
//newdate = (dateFormat.format(date))
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
    tag = VersionNumber (versionNumberString: 'CentOS7.5-${BUILDS_TODAY}-${BUILD_DATE_FORMATTED, "ddMMyyyy"}')
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
        echo "'$tag'"
       // sh "openstack --insecure image set centos-latest --name centos-'$tag'"
       // sh "openstack --insecure image create --disk-format vmdk --file '$VMDKLocation'/packer-vmware-iso-disk1.vmdk centos-latest"
      }
    }
    stage('Build Openstack Test Image') {
      steps {
        echo 'Testing Openstack Image'
      //  sh "openstack --insecure server create --flavor rxp.pl.standard --image centos-latest --network rxpdev packer-test"
      }
    }
    stage('Testing Image'){
      steps {
        echo 'Testing Image'
        //sh "openstack --insecure server list --name packer-test -c Networks"
      }
    }
    stage('Deploy to Artifactory'){
      steps{
        echo 'Pushing to Artifactory'
      }
    }
  }
  post {
    cleanup {
      echo 'Cleaning Up'
    }
  }
}
