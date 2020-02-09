
# Build tarballs and deploy JLL project

Time to generate JLL package. It will wrap C binaries and allow to import them into other projects with Julia's package manager (Pkg).

## Know your options
Get familiar with options of the script with `julia build_tarballs.jl --help` command

## Choose JLL repository

Create empty repo named `sinewave_jll` on github.

Normally binary dependencies are hold in [JuliaBinaryWrappers](https://github.com/JuliaBinaryWrappers/) organisation. If you are going to share your binaries with a wider audience you should consider deploying it there instead of your personal account.

## Deployment

Deploy JLL package and tarballs to the newly created repository.

```
$ julia build_tarballs.jl --deploy=jakubwro/sinewave_jll
```

The script will ask you for github user and password to generate an access token.
If you are not comfortable with typing a password, you can set the token in an environment variable before running the script.

```
$ export GITHUB_TOKEN={put your access token here}
$ julia build_tarballs.jl --deploy=jakubwro/sinewave_jll
```

When script is done JLL module is pushed to your repository and tarballs are visible in [the releases tab](https://github.com/jakubwro/sinewave_jll/releases).

TODO: describe creating a new release
