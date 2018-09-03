Workstation = "/var/lib/jenkins/workspace/packer-test"
Packer = '/var/lib/jenkins/tools/biz.neustar.jenkins.plugins.packer.PackerInstallation/packer'
VMDKLocation = '/var/lib/jenkins/workspace/packer-test/output-vmware-iso/packer-vmware-iso'
remote = [:]
remote.name = 'test'
remote.host = '10.70.2.26'
remote.user = 'root'
remote.password = 'password'
remote.allowAnyHosts = true

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
        //sh "openstack --insecure image set centos-latest --name centos-'$tag'"
        //sh "openstack --insecure image create --disk-format vmdk --file '$VMDKLocation'/packer-vmware-iso-disk1.vmdk '$tag'"
      }
    }
    stage('Build Openstack Test Image') {
      steps {
        echo 'Testing Openstack Image'
        //sh "openstack --insecure server create --flavor rxp.pl.standard --image '$tag' --network rxpdev Packer-'$tag'"
      }
    }
    stage('Testing Image'){
      steps {
        echo 'Testing Image'
        script {
          packer1 = sh "openstack --insecure server list --name Packer-CentOS7.5-2-03092018 -c Networks -f value | awk -F'[/=]' {'print \$2'}"
          echo "${packer1}"
        }
        sshCommand remote: remote, command: "ls -lrt"
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
