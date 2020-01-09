# Devise Sandbox

## THis is a good base build - user auth/user model, save image to aws, sendgrid sign up
Just setting this up quick for fun and to test a few options.<br>
I'll also point out a few pieces of important code in case anyone is looking for something.<br>
Basic Ruby on Rails application with a User Model, Devise for user authentication and S3 bucket to store UserAvatar images.<br>
It uses Sendgrid to email on account verification and password resets.

Check it out if you would like:<br>
<a href="https://devise-sandbox.herokuapp.com" target="_blank">https://devise-sandbox.herokuapp.com</a><br>
You need to make an account to see anything...

# Saving Images
## In Production you need an AWS S3 bucket, an IAM user and a policy for permissions and the connection.
Here is an example:
```
1. grabbing the s3bucket and user from aws:
    1) Create IAM user and grab the keys:

    user: username
    Access Key ID:
    xxxxxxxxxxxxxxgfxgfx
    Secret Access Key:
    xxxfxhxhfxhfxhfxhfxhfxfxhfxhf

    2) Create S3 bucket
      Under services hit S3
      Push Create bucket - name the bucket and select the region
      *make note of the region:

    3) Go back to services and click IAM hit users in the left nav and click into the user

    4) hit policies in the left click get started (if necessary) 

    5) click create policy

    6) Copy an AWS Managed Policy select

    7) search AdministratorAccess and select


    8) Attach policy to IAM user created
    Here is a sample policy, replace the code with your s3 bucket name as needed below:
    {
    "Version": "2012-10-17",
    "Statement": [
    {
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": [
                "arn:aws:s3:::bucketname",
                "arn:aws:s3:::bucketname/*"
                ]
    },
    {
    "Effect": "Allow",
    "Action": "s3:ListAllMyBuckets",
    "Resource": "arn:aws:s3:::*"
    }
    ]
    }

    9) click create policy

    10) go to users and attach the policy under permissions attach policy
```

## Gems for uploads
Using a few gems here carrierwave to upload, mini_magick for any processing of images, fog-aws to save in an S3 bucket
```
#for image uploading
gem 'carrierwave', '~> 2.0'
gem 'mini_magick', '4.9.5'
gem 'fog-aws'
```

## In the uploader you need
```
# Choose what kind of storage to use for this uploader:
if Rails.env.production?
  storage :fog
else
  storage :file
end

# and whitelist file types
def extension_whitelist
 %w(jpg jpeg gif png)
end
```

## get what you need saving to the ENV for heroku/production
```
if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      :aws_access_key_id     => ENV['S3_ACCESS_KEY'],
      :aws_secret_access_key => ENV['S3_SECRET_KEY'],
    }
    config.fog_directory     =  ENV['S3_BUCKET']
  end
end
```

## model user.rb
```
#has many of the image, dependent destroy
has_many :user_avatars, dependent: :destroy
#Allow it to be uploaded on the user form
accepts_nested_attributes_for :user_avatars
```

## model user_avatar.rb
```
mount_uploader :avatar, AvatarUploader
belongs_to :user
validates_size_of :avatar, maximum: 1.megabytes, message: "Upload should be less than 1MB"
```

## Save what you need in the ENV
```
$ heroku config:set S3_BUCKET=xxxxxxxxxxxxxxx -a devise-sandbox
$ heroku config:set S3_ACCESS_KEY=xxxxxxxxxxxxxxx -a devise-sandbox
$ heroku config:set S3_SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -a devise-sandbox

#you will also need SENDGRID_PASSWORD and SENDGRID_USERNAME for sendgrid, 
#those can be set-up through the heroku console
```


...and now we build.

