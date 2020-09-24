describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Version Number Integration" do
      require 'shellwords'

      path = File.absolute_path("./fastlane/spec/fixtures/actions/get_version_number/get_version_number/")

      it "gets the correct version number for 'TargetA'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetA')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      context "Target Settings" do
        it "gets the correct version number for 'TargetVariableParentheses'", requires_xcodeproj: true do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetVariableParentheses')
          end").runner.execute(:test)
          expect(result).to eq("4.3.2")
        end

        it "gets the correct version number for 'TargetVariableCurlyBraces'", requires_xcodeproj: true do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetVariableCurlyBraces')
          end").runner.execute(:test)
          expect(result).to eq("4.3.2")
        end
      end

      context "Project Settings" do
        it "gets the correct version number for 'TargetVariableParenthesesBuildSettings'", requires_xcodeproj: true do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetVariableParenthesesBuildSettings')
          end").runner.execute(:test)
          expect(result).to eq("7.6.5")
        end

        it "gets the correct version number for 'TargetVariableCurlyBracesBuildSettings'", requires_xcodeproj: true do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetVariableCurlyBracesBuildSettings')
          end").runner.execute(:test)
          expect(result).to eq("7.6.5")
        end
      end

      context "xcconfig defined version" do
        it "gets the correct version numer for 'TargetConfigVersion'", requires_xcodeproj: true do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetConfigVersion')
          end").runner.execute(:test)
          expect(result).to eq("4.2.1")
        end
      end

      it "gets the correct version number for 'TargetATests'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetATests')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version number for 'TargetB'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetB')
        end").runner.execute(:test)
        expect(result).to eq("5.4.3")
      end

      it "gets the correct version number for 'TargetBTests'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetBTests')
        end").runner.execute(:test)
        expect(result).to eq("5.4.3")
      end

      it "gets the correct version number for 'TargetC_internal'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetC_internal')
        end").runner.execute(:test)
        expect(result).to eq("7.5.2")
      end

      it "gets the correct version number for 'TargetC_production'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetC_production')
        end").runner.execute(:test)
        expect(result).to eq("6.4.9")
      end

      it "gets the correct version number for 'SampleProject_tests'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'SampleProject_tests')
        end").runner.execute(:test)
        expect(result).to eq("1.0")
      end

      it "gets the correct version number with no target specified (and one target)", requires_xcodeproj: true do
        allow_any_instance_of(Xcodeproj::Project).to receive(:targets).and_wrap_original do |m, *args|
          [m.call(*args).first]
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version number with no target specified (and one target and multiple test targets)", requires_xcodeproj: true do
        allow_any_instance_of(Xcodeproj::Project).to receive(:targets).and_wrap_original do |m, *args|
          targets = m.call(*args)
          targets.select do |target|
            target.name == "TargetA" || target.name == "TargetATests" || target.name == "TargetBTests"
          end
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version with $(SRCROOT)", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetSRC')
        end").runner.execute(:test)
        expect(result).to eq("1.5.9")
      end

      it "gets the correct version when info-plist is relative path", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetRelativePath')
        end").runner.execute(:test)
        expect(result).to eq("3.37.0")
      end

      it "gets the correct version when info-plist is absolute path", requires_xcodeproj: true do
        begin
          # given
          # copy TargetAbsolutePath-Info.plist to /tmp/fastlane_get_version_number_action_spec/
          info_plist = File.absolute_path("./fastlane/spec/fixtures/actions/get_version_number/TargetAbsolutePath-Info.plist")
          temp_folder_for_test = "/tmp/fastlane_get_version_number_action_spec/"
          FileUtils.mkdir_p(temp_folder_for_test)
          FileUtils.cp_r(info_plist, temp_folder_for_test)
          temp_info_plist = File.path(temp_folder_for_test + "TargetAbsolutePath-Info.plist")
          expect(File.file?(temp_info_plist)).not_to(be false)

          # when
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetAbsolutePath')
          end").runner.execute(:test)

          # then
          expect(result).to eq("3.37.4")
        ensure
          # after
          # remove /tmp/fastlane_get_version_number_action_spec/
          FileUtils.rm_r(temp_folder_for_test)
          expect(File.file?(temp_info_plist)).to be false
        end
      end

      it "raises if one target and specified wrong target name", requires_xcodeproj: true do
        allow_any_instance_of(Xcodeproj::Project).to receive(:targets).and_wrap_original do |m, *args|
          [m.call(*args).first]
        end

        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'ThisIsNotATarget')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "Cannot find target named 'ThisIsNotATarget'")
      end

      it "raises if in non-interactive mode with no target", requires_xcodeproj: true do
        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneCrash, /non-interactive mode/)
      end

      it "raises if in non-interactive mode if cannot infer configuration", requires_xcodeproj: true do
        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetDifferentConfigurations')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneCrash, /non-interactive mode/)
      end

      it "gets correct version for different configurations", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetDifferentConfigurations', configuration: 'Debug')
        end").runner.execute(:test)
        expect(result).to eq("1.2.3")

        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetDifferentConfigurations', configuration: 'Release')
        end").runner.execute(:test)
        expect(result).to eq("3.2.1")
      end

      it "raises an exception when use passes workspace" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: 'project.xcworkspace')
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project, not the workspace")
      end
    end
  end
end
