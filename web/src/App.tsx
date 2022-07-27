import * as React from "react";
import Button from "@material-ui/core/Button";
import { useState } from "react";
import { toEnglish } from "./printer";

interface Props {
  name: string;
}

/* <Button variant="contained">this is a material UI button</Button> */

const DEFAULT_PROGRAM = {
  functions: [
    {
      name: "my_add",
      arguments: [
        {
          name: "x",
          type: "any",
        },
        {
          name: "y",
          type: "any",
        },
      ],
      body: [
        {
          out: "z",
          code: {
            function: "add",
            args: [{ variable: "x" }, { variable: "y" }],
          },
        },
        {
          out: null,
          code: {
            function: "add",
            args: [{ const: 1 }, { variable: "z" }],
          },
        },
      ],
    },
    {
      name: "concat_questionmark",
      arguments: [
        {
          name: "text",
          type: "string",
        },
      ],
      body: [
        {
          out: "abc",
          code: {
            function: "concat",
            args: [{ variable: "text" }, { const: "?" }],
          },
        },
        {
          out: null,
          code: {
            function: "concat",
            args: [{ variable: "abc" }, { const: "?" }, { const: "?" }],
          },
        },
      ],
    },
    {
      name: "trim_test",
      arguments: [
        {
          name: "text",
          type: "string",
        },
      ],
      body: [
        {
          out: "x",
          code: {
            function: "trim",
            args: [{ variable: "text" }],
          },
        },
        {
          code: {
            function: "trim",
            args: [{ variable: "x" }, { const: "abc" }],
          },
        },
      ],
    },
  ],
};

const App = ({ name }: Props) => {
  const [x, setX] = useState(DEFAULT_PROGRAM);
  const [y, setY] = useState(JSON.stringify(DEFAULT_PROGRAM, null, 2));

  const changer = (setterX, setterY) => (e) => {
    setterY(e.target.value);
    try {
      setterX(JSON.parse(e.target.value));
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <>
      <h1>Hello {name}</h1>
      {/* <pre>{JSON.stringify(x, null, 2)}</pre> */}
      <pre>{toEnglish(x)}</pre>
      <textarea
        rows={50}
        cols={100}
        value={y}
        onChange={changer(setX, setY)}
      ></textarea>
    </>
  );
};

export default App;
