namespace :users do

	def new_user(name, email, pass, is_admin)
		unless User.where(email: email).exists?
			user = User.create! name: name, email: email, password: pass, password_confirmation: pass
			if is_admin
				user.toggle!(:admin) 
				user.save
			end
		end
	end

	task :create_user, [:name, :email, :pass] => :environment  do |task, args|
		new_user(args[:name], args[:email], args[:pass], false)
	end

	task :create_admin, [:name, :email, :pass] => :environment do |task, args|
		new_user(args[:name], args[:email], args[:pass], true)
	end
end