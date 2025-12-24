# Skip tailwindcss:build when SKIP_TAILWIND_BUILD is set
# Used in Docker builds where CSS is pre-built with npx to support DaisyUI
if ENV["SKIP_TAILWIND_BUILD"]
  Rake::Task["tailwindcss:build"].clear if Rake::Task.task_defined?("tailwindcss:build")
  namespace :tailwindcss do
    task :build do
      puts "Skipping tailwindcss:build (CSS pre-built with npx)"
    end
  end
end
