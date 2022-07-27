const toFunction = (func: string, args: string[]): string => {
  let [first, ...rest] = args;
  let joinedRest = rest.join(" and ");

  switch (true) {
    case func === "add":
      return `${first} add ${joinedRest}`;

    case func == "concat":
      return `${first} combine ${joinedRest}`;

    case func == "trim" && args.length === 1:
      return `trim away from ${first}`;

    case func == "trim" && args.length === 2:
      return `${first} trim with ${joinedRest}`;

    default:
      return "";
  }
};

const toEnglish = (data: any): string => {
  switch (true) {
    case "variable" in data:
      return data.variable;
    case "const" in data:
      return JSON.stringify(data.const);
    case "function" in data:
      return toFunction(data.function, data.args.map(toEnglish));
    case "code" in data && data.out === null:
      return toEnglish(data.code);
    case "code" in data:
      let rest = toEnglish({ ...data, out: null });
      return `set ${data.out} equal to ${rest}`;
    case "arguments" in data && "body" in data:
      let codeBlock = data.body.map(toEnglish);
      let last = codeBlock.pop();
      let inputs = data.arguments.map(toEnglish).join(" and ");
      return `function ${data.name} with inputs ${inputs}:
      ${codeBlock.join("\n")}
      return ${last}
    `;
    case "functions" in data:
      return data.functions.map(toEnglish).join("\n\n");

    case "name" in data && "type" in data:
      return data.name;
    default:
    //   throw Error(JSON.stringify(data));
  }
  return "";
};

export { toEnglish };
