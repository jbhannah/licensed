# frozen_string_literal: true
require "test_helper"
require "tmpdir"

if Licensed::Shell.tool_available?("git")
  describe Licensed::Source::GitSubmodule do
    let(:fixtures) { File.expand_path("../../fixtures/git_submodule/project", __FILE__) }
    let(:config) { Licensed::Configuration.new }
    let(:source) { Licensed::Source::GitSubmodule.new(config) }
    let(:submodule_repo_path) { File.expand_path("../submodule", fixtures) }
    let(:recursive_repo_path) { File.expand_path("../nested", fixtures) }

    def latest_repository_commit(path)
      Dir.chdir(path) do
        Licensed::Git.version(".")
      end
    end

    before do
      Licensed::Git.instance_variable_set("@root", nil)
      Licensed::Git.instance_variable_set("@git", nil)
    end

    after do
      Licensed::Git.instance_variable_set("@root", nil)
      Licensed::Git.instance_variable_set("@git", nil)
    end

    describe "enabled?" do
      it "is true if .gitmodules exists in a git repo" do
        Dir.chdir(fixtures) do
          assert source.enabled?
        end
      end

      it "is false if .gitmodules does not exist" do
        Dir.chdir(Dir.tmpdir) do
          refute source.enabled?
        end
      end
    end

    describe "dependencies" do
      it "finds submodule dependencies" do
        Dir.chdir(fixtures) do
          dep = source.dependencies.find { |d| d["name"] == "submodule" }
          assert dep
          assert_equal latest_repository_commit(submodule_repo_path), dep["version"]
          assert_equal "submodule", dep.name
        end
      end

      it "finds nested submodule dependencies" do
        Dir.chdir(fixtures) do
          dep = source.dependencies.find { |d| d["name"] == "nested" }
          assert dep
          assert_equal latest_repository_commit(recursive_repo_path), dep["version"]
          assert_equal "submodule/nested", dep.name
        end
      end
    end
  end
end
