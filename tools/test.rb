defProperty('slice', 'cdw_', "slice name")
nodes = (0..9).map { |x| "#{x}-#{property.slice}" }

defGroup('all', *nodes) do |g|
end

onEvent(:ALL_NODES_UP) do |event|
  Experiment.done
end