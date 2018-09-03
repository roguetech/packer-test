Workstation = "/var/lib/jenkins/workspace/packer-test"
Packer = '/var/lib/jenkins/tools/biz.neustar.jenkins.plugins.packer.PackerInstallation/packer'
VMDKLocation = '/var/lib/jenkins/workspace/packer-test/output-vmware-iso/packer-vmware-iso'
remote = [:]
remote.name = 'test'
remote.host = ''
remote.user = 'root'
remote.password = 
remote.allowAnyHosts = true
withCredentials([usernamePassword(credentialsId: 'my-pass', passwordVariable: 'password', usernameVariable: 'username')]) {
  remote.user = username
  remote.password = password
  echo "${remote.user}"
  echo "${remote.password}"
}

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
        sh "openstack --insecure image create --disk-format vmdk --file '$VMDKLocation'/packer-vmware-iso-disk1.vmdk '$tag'"
      }
    }
    stage('Build Openstack Test Image') {
      steps {
        echo 'Testing Openstack Image'
        sh "openstack --insecure server create --flavor rxp.pl.standard --image '$tag' --network rxpdev Packer-'$tag'"
      }
    }
    stage('Testing Image'){
      steps {
        echo 'Testing Image'
        script {
          sleep 180
          sh "openstack --insecure server list --name Packer-'$tag' -c Networks -f value | awk -F'[/=]' {'print \$2'} > test.txt"
          remote.host = readFile('test.txt').trim()
          echo "${remote.host}"
          echo "${remote.user}"
          echo "${remote.password}"
        }
        sshCommand remote: remote, command: "ls -lrt"
        sshCommand remote: remote, command: "for i in {1..5}; do echo -n \"Loop \$i \"; date ; sleep 1; done"
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
