whoami="$(juju whoami)"
controller="${JUJU_CONTROLLER:-$(echo "$whoami" | grep Controller | tr -s ' ' | cut -d ' ' -f2)}"
model="${JUJU_MODEL:-$(echo "$whoami" | grep Model | tr -s ' ' | cut -d ' ' -f2)}"
if [ -z "$model" ]; then
    echo "$controller"
else
    echo "$model ($controller)"
fi
