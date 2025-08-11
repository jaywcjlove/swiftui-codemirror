import { nodeResolve } from "@rollup/plugin-node-resolve";
import terser from '@rollup/plugin-terser';
import sizes from 'rollup-plugin-sizes';
export default {
    input: "./codemirror.js",
    output: {
        file: "./web.bundle/codemirror.bundle.js",
        format: "umd",
        extend: true,
        name: "CodeMirror",
        exports: "named",
        plugins: [terser()],
    },
    plugins: [
        nodeResolve(),
        sizes()
    ],
};
