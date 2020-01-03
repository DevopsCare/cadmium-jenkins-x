Manual steps
==
 * Nexus -> S3
 * Jenkins Config - GitHub Server
 * Jenkins Config - add env "GLOBAL_ENABLED_ENVIRONMENT_TYPE: K8 Namespace"
 * Jenkins - create GitHub organization, filter on PROJECTPREFIX-*, autobuild "master"
 * Jenkins add plugins
   * Script Security - update, then disable :)
   * jobDSL
   * Basic Branch Build Strategies (and migrate if needed)
   * Pipeline Utility Steps
   * timestamper
   * OWASP markdown
   * Pipeline utility steps
   

Adding CVE (WIP)
==
```bash
aws-vault exec `cat .aws-profile` -- jx ns jx
aws-vault exec `cat .aws-profile` -- jx create addon anchore
```

Staging Env creation steps (semi-automatic)
==
First we fetch the template
```bash
mkdir my_infra && cd my_infra
git init
git remote add origin https://github.com/GITHUB_ORG/PROJECT-infra # Change to real application repo
git remote add upstream https://github.com/jenkins-x/default-environment-charts
git fetch --all
git reset --hard remotes/upstream/master
```

Then replace template vars and push new version
```bash
export DOMAIN=PROJECT.example.com

sed -i "/expose:/a\ \ config:\n\ \ \ \ tlsacme: \"true\"\n\ \ \ \ domain: $DOMAIN" env/values.yaml

grep -rl --exclude-dir=.git 'change-me' --null | xargs -0 sed -i -e "s/change-me/jx-staging/g"
git commit -a -m "fix: init as jx-staging at $DOMAIN"
git push -f origin master

```

And register new environment in JX (say "no" to creating new repo and specify existing)
```bash
aws-vault exec `cat .aws-profile` -- jx ns jx
# optional: aws-vault exec --assume-role-ttl=1h `cat .aws-profile` -- jx create jenkins token 
aws-vault exec `cat .aws-profile` -- jx create environment -n staging -l Staging -s jx-staging
```

Then remove folder from Jenkins if you using GitHub organization with auto-discover.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| default\_admin\_password | n/a | `string` | n/a | yes |
| domain | n/a | `string` | n/a | yes |
| environment\_git\_owner | n/a | `string` | n/a | yes |
| git\_api\_token | n/a | `string` | n/a | yes |
| git\_provider | n/a | `string` | `"github"` | no |
| git\_username | n/a | `string` | n/a | yes |
| jx\_platform\_version | n/a | `string` | `"2.0.1800"` | no |
| kubeconfig\_filename | n/a | `any` | n/a | yes |

## Outputs

No output.

